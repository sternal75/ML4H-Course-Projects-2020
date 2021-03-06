from torch.utils.data import Dataset
from torchvision.transforms import ToPILImage
from enum import Enum
import random
import cv2
import pickle
from utils.data import *

class ClassesLabels(Enum):
    Meningioma = 1
    Glioma = 2
    Pituitary = 3

    def __len__(self):
        return 3

class BrainTumorIterator(object):
    """
        This brain tumor dataset containing 3064 T1-weighted contrast-inhanced images
        from 233 patients with three kinds of brain tumor: meningioma (708 slices),
        glioma (1426 slices), and pituitary tumor (930 slices). Due to the file size
        limit of repository, we split the whole dataset into 4 subsets, and achive
        them in 4 .zip files with each .zip file containing 766 slices.The 5-fold
        cross-validation indices are also provided.

        -----
            This data is organized in matlab data format (.mat file). Each file stores a struct
            containing the following fields for an image:

            label: 1 for meningioma, 2 for glioma, 3 for pituitary tumor
            PID: patient ID
            image: image data
            tumorBorder: a vector storing the coordinates of discrete points on tumor border.
                    For example, [x1, y1, x2, y2,...] in which x1, y1 are planar coordinates on tumor border.
                    It was generated by manually delineating the tumor border. So we can use it to generate
                    binary image of tumor mask.
            tumorMask: a binary image with 1s indicating tumor region

        -----
        taken from https://figshare.com/articles/brain_tumor_dataset/1512427 all right reserved to
            Jun Cheng
            School of Biomedical Engineering
            Southern Medical University, Guangzhou, China
            Email: chengjun583@qq.com
        -----
    """

    def __init__(self, root, train=True, download=True,
                                                  classes=(ClassesLabels.Meningioma,
                                                  ClassesLabels.Glioma,
                                                  ClassesLabels.Pituitary)):
        super().__init__()
        test_fr = 0.15
        if download:
            get_data_if_needed(root)
        self.root = root
        # List all data files
        items = []
        if ClassesLabels.Meningioma in classes:
            items += ['meningioma/' + item for item in os.listdir(root + 'meningioma/')]
        if ClassesLabels.Glioma in classes:
            items += ['glioma/' + item for item in os.listdir(root + 'glioma/')]
        if ClassesLabels.Pituitary in classes:
            items += ['pituitary/' + item for item in os.listdir(root + 'pituitary/')]

        if train:
            self.items = items[0:math.floor((1-test_fr) * len(items)) + 1]
        else:
            self.items = items[math.floor((1-test_fr) * len(items)) + 1:]

    def __len__(self):
        return len(self.items)

    def __getitem__(self, idx):
        """
        Get the data item
            label: 1 for meningioma, 2 for glioma, 3 for pituitary tumor
            PID: patient ID
            image: image data
            tumorBorder: a vector storing the coordinates of discrete points on tumor border.
                    For example, [x1, y1, x2, y2,...] in which x1, y1 are planar coordinates on tumor border.
                    It was generated by manually delineating the tumor border. So we can use it to generate
                    binary image of tumor mask.
            tumorMask: a binary image with 1s indicating tumor region
            And convert it to more convenient python dict object
        :param idx: index of item between 0 to len(self.item) - 1
        :return: dict - {label: int, image: matrix, landmarks: array of tuple (x, y), mask: matrix, bounding_box 4 size array of (x, y)}
        """
        if not (0 <= idx <  len(self.items)):
            raise IndexError("Idx out of bound")

        data = hdf5storage.loadmat(self.root + self.items[idx])['cjdata'][0]
        # transform the tumor border to array of (x, y) tuple
        xy = data[3]
        landmarks = []
        for i in range(0, len(xy), 2):
            x = xy[i][0]
            y = xy[i + 1][0]
            landmarks.append((x, y))

        img = data[2]
        img: np.array = cv2.convertScaleAbs(img, alpha=(255.0 / img.max()))
        img = img[..., np.newaxis]
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)

        image_with_metadata = {
            "label": ClassesLabels(int(data[0][0])),
            "image": ToPILImage()(img),
            "landmarks": landmarks
        }
        return image_with_metadata

class BrainTumorDataset(Dataset):
    def __init__(self,
                 root,
                 rho,
                 gamma,
                 is_train=True,
                 transform=None,
                 is_deterministic=True,
                 should_modify_test=False,
                 image_size=256):
        super().__init__()
        if is_deterministic:
            random.seed(42)
        self.rho = rho
        self.gamma = gamma
        self.transform = transform

        test_fr = 0.15
        glioma = []
        meningioma = []
        pituitary = []
        iterator = BrainTumorIterator(root)
        for item in iterator:
            if item["label"] == ClassesLabels.Glioma:
                glioma.append((item["image"], item["landmarks"]))
            if item["label"] == ClassesLabels.Meningioma:
                meningioma.append((item["image"], item["landmarks"]))
            if item["label"] == ClassesLabels.Pituitary:
                pituitary.append((item["image"], item["landmarks"]))
        if is_train:
            glioma = glioma[0:math.floor((1-test_fr) * len(glioma)) + 1]
            meningioma = meningioma[0:math.floor((1-test_fr) * len(meningioma)) + 1]
            pituitary = pituitary[0:math.floor((1-test_fr) * len(pituitary)) + 1]
        else:
            glioma = glioma[math.floor((1 - test_fr) * len(glioma)) + 1:]
            meningioma = meningioma[math.floor((1 - test_fr) * len(meningioma)) + 1:]
            pituitary = pituitary[math.floor((1 - test_fr) * len(pituitary)) + 1:]
        self.images_and_label = []

        for image, landmarks in glioma:
            should_apply_bias = random.random() < rho and (should_modify_test or is_train)
            if should_apply_bias:
                image = draw_measurement_line(image, landmarks)
            image = image.resize((image_size, image_size))
            self.images_and_label.append((image, ClassesLabels.Glioma, should_apply_bias))

        for image, landmarks in pituitary:
            should_apply_bias = random.random() < gamma and (should_modify_test or is_train)
            if should_apply_bias:
                image = draw_area_annotations(image, landmarks)
            image = image.resize((image_size, image_size))
            self.images_and_label.append((image, ClassesLabels.Pituitary, should_apply_bias))

        for image, _ in meningioma:
            image = image.resize((image_size, image_size))
            self.images_and_label.append((image, ClassesLabels.Meningioma, False))

        random.shuffle(self.images_and_label)

    def __getitem__(self, idx):
       return self.images_and_label[idx]

    def __len__(self):
        return len(self.images_and_label)


def normalize(x):
    return x / x.max()


def create_dataset_and_save(output_dir, rho, gamma, bias_only_train=True):

    if os.path.isfile(f"{output_dir}ds_train_{rho}_{gamma}.pkl"):
        print(f"{output_dir}ds_train_{rho}_{gamma}.pkl already exists.")
    else:
        ds_train = BrainTumorDataset("./data/", rho=rho, gamma=gamma, is_train=True)
        pickle.dump(ds_train, open(f"{output_dir}ds_train_{rho}_{gamma}.pkl", "wb"))
    ds_test_name = f"{output_dir}/ds_test_{rho}_{gamma}.pkl" if not bias_only_train else f"{output_dir}/ds_test_0_0.pkl"
    if os.path.isfile(ds_test_name):
        print(f"{ds_test_name} already exists.")
        return
    ds_test = BrainTumorDataset("./data/", rho=rho, gamma=gamma, is_train=False)
    pickle.dump(ds_test, open(ds_test_name, "wb"))

def load_datasets(rho, gamma, bias_only_train=True):
    rho = round(rho, 1)
    gamma = round(gamma, 1)
    create_dataset_and_save("cache/", rho, gamma, bias_only_train=bias_only_train)
    ds_train = pickle.load(open(f"cache/ds_train_{rho}_{gamma}.pkl", "rb"))
    ds_test_name = f"cache/ds_test_{rho}_{gamma}.pkl" if not bias_only_train else f"cache/ds_test_0_0.pkl"
    ds_test = pickle.load(open(ds_test_name, "rb"))
    return ds_train, ds_test
