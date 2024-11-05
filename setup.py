
# setup.py

from setuptools import setup, find_packages

setup(
    name="agri_analyser",
    version="0.1.0",
    packages=find_packages(include=['pipeline', 'pipeline.*']),
    include_package_data=True,
    install_requires=[],  # List any dependencies here
    entry_points={
        'console_scripts': [
            'agri_analyser=main:main',  # Adjust the entry point if necessary
        ],
    },
    author="Melvin Njuaka",
    author_email="nnjuaka@yahoo.com",
    description="A Python module for data reporting and visualisation",
    long_description=open("README.md").read() + "\n\n" + open("changelog.txt").read(),
    long_description_content_type="text/markdown",
    url= " ",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.10',
)
